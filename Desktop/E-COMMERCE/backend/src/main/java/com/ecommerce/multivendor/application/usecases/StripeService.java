package com.ecommerce.multivendor.application.usecases;

import com.ecommerce.multivendor.application.dto.PaymentIntentResponse;
import com.ecommerce.multivendor.domain.entities.Order;
import com.ecommerce.multivendor.domain.repositories.OrderRepository;
import com.stripe.Stripe;
import com.stripe.exception.StripeException;
import com.stripe.model.PaymentIntent;
import com.stripe.param.PaymentIntentCreateParams;
import jakarta.annotation.PostConstruct;
import lombok.RequiredArgsConstructor;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.UUID;

@Service
@RequiredArgsConstructor
public class StripeService {

    @Value("${stripe.api.key}")
    private String stripeApiKey;

    private final OrderRepository orderRepository;

    @PostConstruct
    public void init() {
        Stripe.apiKey = stripeApiKey;
    }

    public PaymentIntentResponse createPaymentIntent(String orderId) throws StripeException {
        Order order = orderRepository.findById(UUID.fromString(orderId))
                .orElseThrow(() -> new IllegalArgumentException("Order not found"));

        // Stripe expects amounts in cents
        long amount = order.getTotalAmount().multiply(new BigDecimal(100)).longValue();

        PaymentIntentCreateParams params =
                PaymentIntentCreateParams.builder()
                        .setAmount(amount)
                        .setCurrency("usd")
                        .putMetadata("orderId", orderId)
                        .build();

        PaymentIntent paymentIntent = PaymentIntent.create(params);

        return PaymentIntentResponse.builder()
                .clientSecret(paymentIntent.getClientSecret())
                .build();
    }

    @Value("${stripe.webhook.secret}")
    private String endpointSecret;

    public void handleWebhook(String payload, String sigHeader) throws Exception {
        com.stripe.model.Event event = com.stripe.net.Webhook.constructEvent(
                payload, sigHeader, endpointSecret
        );

        if ("payment_intent.succeeded".equals(event.getType())) {
            PaymentIntent paymentIntent = (PaymentIntent) event.getDataObjectDeserializer().getObject().orElse(null);
            if (paymentIntent != null && paymentIntent.getMetadata() != null) {
                String orderIdStr = paymentIntent.getMetadata().get("orderId");
                if (orderIdStr != null) {
                    Order order = orderRepository.findById(UUID.fromString(orderIdStr)).orElse(null);
                    if (order != null) {
                        order.setPaymentStatus("PAID");
                        // Only change status if it's currently PAYMENT_PENDING or PROCESSING
                        if (order.getStatus().equals("PAYMENT_PENDING")) {
                            order.setStatus("PROCESSING");
                        }
                        orderRepository.save(order);
                    }
                }
            }
        }
    }
}

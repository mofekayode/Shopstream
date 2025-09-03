# ADR-001: Use AWS Cognito for Authentication

**Date:** 2025-01-03
**Status:** Accepted
**Author:** Platform Team

## Context
We need a robust, scalable authentication solution for Shopstream that handles user registration, login, MFA, password resets, and token management without reinventing the wheel.

## Decision
We will use **AWS Cognito** as our managed authentication service instead of implementing authentication from scratch.

## Consequences

### Positive
- **Security**: Battle-tested, SOC 2 compliant, handles OWASP top 10 auth concerns
- **Features**: Built-in MFA, password policies, account recovery, email verification
- **Scalability**: Handles millions of users without custom infrastructure
- **Standards**: OAuth 2.0, OpenID Connect, SAML 2.0 support
- **Integration**: Native AWS integration with API Gateway, ALB, CloudFront
- **Cost**: Pay per monthly active user (first 50K free)
- **Compliance**: HIPAA eligible, PCI DSS, SOC compliant

### Negative
- **Vendor Lock-in**: Migration away from Cognito requires significant effort
- **Customization**: Limited UI customization for hosted pages
- **Latency**: Additional network hop vs. in-service auth
- **Learning Curve**: Team needs to learn Cognito specifics

### Neutral
- **Token Management**: JWT tokens with 1-hour access, 30-day refresh defaults
- **User Pools**: Separate user pools for different environments
- **Triggers**: Lambda triggers for custom auth flows if needed

## Alternatives Considered

### 1. Auth0
- **Pros**: More flexible, better developer experience, social logins
- **Cons**: Higher cost, another vendor to manage, not AWS-native

### 2. Custom JWT Implementation
- **Pros**: Full control, no vendor lock-in
- **Cons**: Security risk, maintenance burden, need to handle:
  - Password hashing (bcrypt/argon2)
  - Token rotation
  - Session management
  - Rate limiting
  - Account lockout
  - Password reset flows
  - Email verification
  - MFA implementation

### 3. Keycloak (self-hosted)
- **Pros**: Open source, full control, enterprise features
- **Cons**: Operational overhead, needs dedicated infrastructure

## Implementation Details

### User Pool Configuration
```javascript
{
  passwordPolicy: {
    minimumLength: 12,
    requireLowercase: true,
    requireUppercase: true,
    requireNumbers: true,
    requireSymbols: true
  },
  mfa: 'OPTIONAL', // Users can enable
  accountRecovery: 'EMAIL',
  emailVerification: 'REQUIRED',
  advancedSecurity: 'ENFORCED'
}
```

### Token Strategy
- Access tokens: 15 minutes (short-lived)
- Refresh tokens: 7 days (rotate on use)
- ID tokens: Contains user claims for frontend

### Integration Points
- **identity-service**: Wraps Cognito APIs
- **API Gateway**: Cognito authorizers for REST endpoints
- **Frontend**: Amplify Auth library or AWS SDK

## Migration Path
If we need to migrate away from Cognito:
1. Export user pool (emails, attributes)
2. Implement new auth service
3. Dual-write during transition
4. Migrate passwords on next login
5. Deprecate Cognito pool

## References
- [AWS Cognito Best Practices](https://docs.aws.amazon.com/cognito/latest/developerguide/best-practices.html)
- [OWASP Authentication Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Authentication_Cheat_Sheet.html)
- [JWT Best Practices](https://tools.ietf.org/html/rfc8725)
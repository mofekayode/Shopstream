import rateLimit from 'express-rate-limit';
import { Request } from 'express';

// Check if we're behind API Gateway (production) or running locally
const isProduction = process.env.NODE_ENV === 'production';
const isBehindApiGateway = process.env.API_GATEWAY_ENABLED === 'true';

// Custom key generator that respects API Gateway headers
const keyGenerator = (req: Request): string => {
  // If behind API Gateway, use the forwarded IP
  if (isBehindApiGateway && req.headers['x-forwarded-for']) {
    const forwarded = req.headers['x-forwarded-for'] as string;
    return forwarded.split(',')[0].trim();
  }
  // Fallback to standard IP detection
  return req.ip || 'unknown';
};

// Skip rate limiting if API Gateway is handling it
const skip = (_req: Request): boolean => {
  // In production with API Gateway, let API Gateway handle rate limiting
  return isProduction && isBehindApiGateway;
};

// Create the rate limiters without type assertions
const generalLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // Limit each IP to 100 requests per windowMs
  message: 'Too many requests from this IP, please try again later.',
  standardHeaders: true, // Return rate limit info in `RateLimit-*` headers
  legacyHeaders: false,
  keyGenerator: keyGenerator as any,
  skip: skip as any,
  handler: (_req, res) => {
    res.status(429).json({
      error: 'Too Many Requests',
      message: 'Too many requests from this IP, please try again later.',
      retryAfter: res.getHeader('Retry-After'),
    });
  },
});

const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // Limit each IP to 5 auth requests per windowMs
  message: 'Too many authentication attempts, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
  skipSuccessfulRequests: true, // Don't count successful requests
  keyGenerator: keyGenerator as any,
  skip: skip as any,
  handler: (_req, res) => {
    res.status(429).json({
      error: 'Too Many Requests',
      message: 'Too many authentication attempts, please try again later.',
      retryAfter: res.getHeader('Retry-After'),
    });
  },
});

// Export the middleware instances
export { generalLimiter as rateLimiter, authLimiter as authRateLimiter };
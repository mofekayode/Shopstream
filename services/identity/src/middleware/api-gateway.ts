import { Request, Response, NextFunction } from 'express';
import { createLogger } from '@shopstream/platform-lib';

const logger = createLogger('api-gateway-middleware');

declare global {
  namespace Express {
    interface Request {
      apiGateway?: {
        apiKey?: string;
        sourceIp?: string;
        traceId?: string;
        requestId?: string;
        stage?: string;
      };
    }
  }
}

/**
 * Middleware to handle API Gateway specific headers and context
 */
export function apiGatewayMiddleware(req: Request, _res: Response, next: NextFunction) {
  // Extract API Gateway headers
  req.apiGateway = {
    apiKey: req.headers['x-api-key'] as string,
    sourceIp: (req.headers['x-forwarded-for'] as string)?.split(',')[0]?.trim() || req.ip,
    traceId: req.headers['x-amz-trace-id'] as string,
    requestId: req.headers['x-amzn-requestid'] as string || req.headers['x-request-id'] as string,
    stage: req.headers['x-amzn-stage'] as string,
  };

  // Log API Gateway context
  if (req.apiGateway.requestId) {
    logger.debug('API Gateway request', {
      requestId: req.apiGateway.requestId,
      apiKey: req.apiGateway.apiKey ? '***' : undefined,
      sourceIp: req.apiGateway.sourceIp,
      traceId: req.apiGateway.traceId,
      stage: req.apiGateway.stage,
      path: req.path,
      method: req.method,
    });
  }

  // Set trace ID for distributed tracing
  if (req.apiGateway.traceId) {
    // This will be picked up by OpenTelemetry
    process.env._X_AMZN_TRACE_ID = req.apiGateway.traceId;
  }

  next();
}

/**
 * Middleware to validate API key if required
 */
export function requireApiKey(req: Request, res: Response, next: NextFunction) {
  // Skip in development/test environments
  if (process.env.NODE_ENV !== 'production' && process.env.API_KEY_REQUIRED !== 'true') {
    return next();
  }

  const apiKey = req.apiGateway?.apiKey || req.headers['x-api-key'];

  if (!apiKey) {
    logger.warn('Missing API key', {
      sourceIp: req.apiGateway?.sourceIp || req.ip,
      path: req.path,
    });
    
    return res.status(403).json({
      error: 'Forbidden',
      message: 'API key is required',
    });
  }

  // API Gateway validates the key, we just check it exists
  // Additional validation could be added here if needed
  next();
}

/**
 * Middleware to add API Gateway compatible response headers
 */
export function apiGatewayResponseHeaders(_req: Request, res: Response, next: NextFunction) {
  // Add CORS headers that work well with API Gateway
  res.setHeader('X-Content-Type-Options', 'nosniff');
  res.setHeader('X-Frame-Options', 'DENY');
  res.setHeader('X-XSS-Protection', '1; mode=block');
  
  // Add cache control headers
  if (process.env.NODE_ENV === 'production') {
    res.setHeader('Cache-Control', 'no-store, no-cache, must-revalidate, proxy-revalidate');
    res.setHeader('Pragma', 'no-cache');
    res.setHeader('Expires', '0');
  }

  next();
}
import { Request, Response, NextFunction } from 'express';
import { CognitoAuthService, createLogger } from '@shopstream/platform-lib';

const logger = createLogger('auth-middleware');
const authService = new CognitoAuthService();

declare global {
  namespace Express {
    interface Request {
      user?: {
        sub: string;
        email: string;
        roles?: string[];
        [key: string]: any;
      };
    }
  }
}

export async function authenticate(req: Request, res: Response, next: NextFunction) {
  try {
    const token = req.headers.authorization?.replace('Bearer ', '');

    if (!token) {
      return res.status(401).json({ error: 'No token provided' });
    }

    const decoded = await authService.verifyAccessToken(token);
    
    req.user = {
      sub: decoded.sub,
      email: decoded.email || decoded['cognito:username'],
      roles: decoded['custom:roles']?.split(',') || [],
      ...decoded,
    };

    next();
    return;
  } catch (error: any) {
    logger.error('Authentication failed:', error);
    
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ error: 'Token expired' });
    }
    
    return res.status(401).json({ error: 'Invalid token' });
  }
}
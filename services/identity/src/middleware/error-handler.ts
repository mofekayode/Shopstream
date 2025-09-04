import { Request, Response, NextFunction } from 'express';
import { createLogger } from '@shopstream/platform-lib';

const logger = createLogger('error-handler');

export function errorHandler(err: any, req: Request, res: Response, next: NextFunction) {
  logger.error('Error:', err);

  // Cognito errors
  if (err.name === 'UsernameExistsException') {
    return res.status(409).json({ error: 'User already exists' });
  }

  if (err.name === 'CodeMismatchException') {
    return res.status(400).json({ error: 'Invalid verification code' });
  }

  if (err.name === 'NotAuthorizedException') {
    return res.status(401).json({ error: 'Invalid credentials' });
  }

  if (err.name === 'UserNotFoundException') {
    return res.status(404).json({ error: 'User not found' });
  }

  if (err.name === 'UserNotConfirmedException') {
    return res.status(400).json({ error: 'User email not confirmed' });
  }

  // DynamoDB errors
  if (err.name === 'ResourceNotFoundException') {
    return res.status(500).json({ error: 'Database table not found' });
  }

  if (err.name === 'ValidationException') {
    return res.status(400).json({ error: 'Invalid request data' });
  }

  // Default error
  return res.status(err.status || 500).json({
    error: err.message || 'Internal server error',
    ...(process.env.NODE_ENV === 'development' && { stack: err.stack }),
  });
}
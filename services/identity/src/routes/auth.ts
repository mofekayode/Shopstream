import { Router } from 'express';
import { z } from 'zod';
import { CognitoAuthService, createLogger } from '@shopstream/platform-lib';
import { validateRequest } from '../middleware/validate-request';
import { createUser, getUserByEmail } from '../services/user-service';

const router = Router();
const logger = createLogger('auth-routes');
const authService = new CognitoAuthService();

// Validation schemas
const signUpSchema = z.object({
  email: z.string().email(),
  password: z.string().min(8),
  firstName: z.string().min(1),
  lastName: z.string().min(1),
  phoneNumber: z.string().optional(),
});

const signInSchema = z.object({
  email: z.string().email(),
  password: z.string(),
});

const confirmSignUpSchema = z.object({
  email: z.string().email(),
  code: z.string().length(6),
});

const refreshTokenSchema = z.object({
  refreshToken: z.string(),
});

// Sign up endpoint
router.post('/signup', validateRequest(signUpSchema), async (req, res, next) => {
  try {
    const { email, password, firstName, lastName, phoneNumber } = req.body;

    // Sign up with Cognito
    const cognitoUser = await authService.signUp(email, password);

    // Create user in DynamoDB
    const user = await createUser({
      id: cognitoUser.userId,
      email,
      firstName,
      lastName,
      phoneNumber,
      status: 'PENDING_CONFIRMATION',
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString(),
    });

    logger.info(`User signed up: ${email}`);

    res.status(201).json({
      message: 'User created successfully. Please check your email for verification code.',
      userId: user.id,
      email: user.email,
    });
  } catch (error) {
    next(error);
  }
});

// Confirm sign up endpoint
router.post('/confirm', validateRequest(confirmSignUpSchema), async (req, res, next) => {
  try {
    const { email, code } = req.body;

    await authService.confirmSignUp(email, code);

    // Update user status in DynamoDB
    const user = await getUserByEmail(email);
    if (user) {
      user.status = 'ACTIVE';
      user.updatedAt = new Date().toISOString();
      await createUser(user); // This will update the existing user
    }

    logger.info(`User confirmed: ${email}`);

    res.json({
      message: 'Email confirmed successfully. You can now sign in.',
    });
  } catch (error) {
    next(error);
  }
});

// Sign in endpoint
router.post('/signin', validateRequest(signInSchema), async (req, res, next) => {
  try {
    const { email, password } = req.body;

    const tokens = await authService.signIn(email, password);

    // Update last login in DynamoDB
    const user = await getUserByEmail(email);
    if (user) {
      user.lastLoginAt = new Date().toISOString();
      user.updatedAt = new Date().toISOString();
      await createUser(user); // This will update the existing user
    }

    logger.info(`User signed in: ${email}`);

    res.json({
      accessToken: tokens.accessToken,
      refreshToken: tokens.refreshToken,
      idToken: tokens.idToken,
      expiresIn: tokens.expiresIn,
    });
  } catch (error) {
    next(error);
  }
});

// Refresh token endpoint
router.post('/refresh', validateRequest(refreshTokenSchema), async (req, res, next) => {
  try {
    const { refreshToken } = req.body;

    const tokens = await authService.refreshTokens(refreshToken);

    res.json({
      accessToken: tokens.accessToken,
      idToken: tokens.idToken,
      expiresIn: tokens.expiresIn,
    });
  } catch (error) {
    next(error);
  }
});

// Sign out endpoint
router.post('/signout', async (req, res, next) => {
  try {
    const accessToken = req.headers.authorization?.replace('Bearer ', '');
    
    if (accessToken) {
      // Cognito handles token revocation
      // We just acknowledge the signout
      logger.info('User signed out');
    }

    res.json({
      message: 'Signed out successfully',
    });
  } catch (error) {
    next(error);
  }
});

export { router as authRouter };
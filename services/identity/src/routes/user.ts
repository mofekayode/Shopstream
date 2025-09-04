import { Router } from 'express';
import { z } from 'zod';
import { authenticate } from '../middleware/authenticate';
import { validateRequest } from '../middleware/validate-request';
import { getUserById, getUserByEmail, updateUser, deleteUser } from '../services/user-service';
import { createLogger } from '@shopstream/platform-lib';

const router = Router();
const logger = createLogger('user-routes');

const updateUserSchema = z.object({
  firstName: z.string().optional(),
  lastName: z.string().optional(),
  phoneNumber: z.string().optional(),
  preferences: z.record(z.any()).optional(),
});

// Get current user
router.get('/me', authenticate, async (req, res, next) => {
  try {
    const userId = req.user!.sub;
    const user = await getUserById(userId);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    next(error);
  }
});

// Update current user
router.patch('/me', authenticate, validateRequest(updateUserSchema), async (req, res, next) => {
  try {
    const userId = req.user!.sub;
    const updates = req.body;

    const user = await getUserById(userId);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    const updatedUser = await updateUser(userId, {
      ...updates,
      updatedAt: new Date().toISOString(),
    });

    logger.info(`User updated: ${userId}`);
    res.json(updatedUser);
  } catch (error) {
    next(error);
  }
});

// Delete current user
router.delete('/me', authenticate, async (req, res, next) => {
  try {
    const userId = req.user!.sub;

    await deleteUser(userId);

    logger.info(`User deleted: ${userId}`);
    res.status(204).send();
  } catch (error) {
    next(error);
  }
});

// Admin: Get user by ID
router.get('/:userId', authenticate, async (req, res, next) => {
  try {
    // Check if user is admin
    if (!req.user?.roles?.includes('admin')) {
      return res.status(403).json({ error: 'Forbidden' });
    }

    const user = await getUserById(req.params.userId);

    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }

    res.json(user);
  } catch (error) {
    next(error);
  }
});

export { router as userRouter };
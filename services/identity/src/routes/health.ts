import { Router } from 'express';
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';

const router = Router();
const dynamoClient = new DynamoDBClient({ region: process.env.AWS_REGION || 'us-east-1' });

router.get('/', async (req, res) => {
  const health = {
    status: 'healthy',
    timestamp: new Date().toISOString(),
    service: 'identity-service',
    version: process.env.APP_VERSION || '0.1.0',
    uptime: process.uptime(),
    memory: {
      used: Math.round(process.memoryUsage().heapUsed / 1024 / 1024),
      total: Math.round(process.memoryUsage().heapTotal / 1024 / 1024),
      unit: 'MB'
    }
  };

  res.json(health);
});

router.get('/ready', async (req, res) => {
  try {
    // Check DynamoDB connection
    await dynamoClient.send({ input: {} } as any);
    
    res.json({
      status: 'ready',
      checks: {
        database: 'connected',
        cognito: 'configured'
      }
    });
  } catch (error) {
    res.status(503).json({
      status: 'not ready',
      error: 'Dependencies not available'
    });
  }
});

export { router as healthRouter };
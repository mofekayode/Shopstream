import { DynamoDBClient } from '@aws-sdk/client-dynamodb';
import { DynamoDBDocumentClient, GetCommand, PutCommand, UpdateCommand, DeleteCommand, QueryCommand } from '@aws-sdk/lib-dynamodb';
import { createLogger } from '@shopstream/platform-lib';

const logger = createLogger('user-service');

const client = new DynamoDBClient({
  region: process.env.AWS_REGION || 'us-east-1',
});

const docClient = DynamoDBDocumentClient.from(client);

const TABLE_NAME = process.env.USERS_TABLE_NAME || 'shopstream-users';

export interface User {
  id: string; // Cognito sub
  email: string;
  firstName: string;
  lastName: string;
  phoneNumber?: string;
  status: 'PENDING_CONFIRMATION' | 'ACTIVE' | 'SUSPENDED' | 'DELETED';
  roles?: string[];
  preferences?: Record<string, any>;
  lastLoginAt?: string;
  createdAt: string;
  updatedAt: string;
}

export async function createUser(user: User): Promise<User> {
  try {
    await docClient.send(new PutCommand({
      TableName: TABLE_NAME,
      Item: user,
      ConditionExpression: 'attribute_not_exists(id)',
    }));

    logger.info(`User created: ${user.id}`);
    return user;
  } catch (error: any) {
    if (error.name === 'ConditionalCheckFailedException') {
      // User already exists, update instead
      return updateUser(user.id, user);
    }
    logger.error('Error creating user:', error);
    throw error;
  }
}

export async function getUserById(userId: string): Promise<User | null> {
  try {
    const result = await docClient.send(new GetCommand({
      TableName: TABLE_NAME,
      Key: { id: userId },
    }));

    return result.Item as User || null;
  } catch (error) {
    logger.error(`Error getting user ${userId}:`, error);
    throw error;
  }
}

export async function getUserByEmail(email: string): Promise<User | null> {
  try {
    const result = await docClient.send(new QueryCommand({
      TableName: TABLE_NAME,
      IndexName: 'email-index',
      KeyConditionExpression: 'email = :email',
      ExpressionAttributeValues: {
        ':email': email,
      },
      Limit: 1,
    }));

    return result.Items?.[0] as User || null;
  } catch (error) {
    logger.error(`Error getting user by email ${email}:`, error);
    throw error;
  }
}

export async function updateUser(userId: string, updates: Partial<User>): Promise<User> {
  try {
    const updateExpressions: string[] = [];
    const expressionAttributeNames: Record<string, string> = {};
    const expressionAttributeValues: Record<string, any> = {};

    Object.entries(updates).forEach(([key, value]) => {
      if (key !== 'id') {
        updateExpressions.push(`#${key} = :${key}`);
        expressionAttributeNames[`#${key}`] = key;
        expressionAttributeValues[`:${key}`] = value;
      }
    });

    const result = await docClient.send(new UpdateCommand({
      TableName: TABLE_NAME,
      Key: { id: userId },
      UpdateExpression: `SET ${updateExpressions.join(', ')}`,
      ExpressionAttributeNames: expressionAttributeNames,
      ExpressionAttributeValues: expressionAttributeValues,
      ReturnValues: 'ALL_NEW',
    }));

    logger.info(`User updated: ${userId}`);
    return result.Attributes as User;
  } catch (error) {
    logger.error(`Error updating user ${userId}:`, error);
    throw error;
  }
}

export async function deleteUser(userId: string): Promise<void> {
  try {
    await docClient.send(new DeleteCommand({
      TableName: TABLE_NAME,
      Key: { id: userId },
    }));

    logger.info(`User deleted: ${userId}`);
  } catch (error) {
    logger.error(`Error deleting user ${userId}:`, error);
    throw error;
  }
}
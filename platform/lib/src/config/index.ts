import { SecretsManagerClient, GetSecretValueCommand } from '@aws-sdk/client-secrets-manager';

export interface Config {
  NODE_ENV: string;
  AWS_REGION: string;
  SERVICE_NAME: string;
  LOG_LEVEL: string;
  PORT: number;
}

class ConfigService {
  private cache: Map<string, any> = new Map();
  private secretsClient?: SecretsManagerClient;

  constructor() {
    if (process.env.AWS_REGION) {
      this.secretsClient = new SecretsManagerClient({
        region: process.env.AWS_REGION,
      });
    }
  }

  get<T = string>(key: string, defaultValue?: T): T {
    const cached = this.cache.get(key);
    if (cached !== undefined) return cached;

    const value = process.env[key] || defaultValue;
    if (value === undefined) {
      throw new Error(`Configuration key "${key}" is not defined`);
    }

    this.cache.set(key, value);
    return value as T;
  }

  getNumber(key: string, defaultValue?: number): number {
    const value = this.get(key, defaultValue?.toString());
    return parseInt(value as string, 10);
  }

  getBoolean(key: string, defaultValue = false): boolean {
    const value = this.get(key, defaultValue.toString());
    return value === 'true' || value === '1';
  }

  async getSecret(secretId: string): Promise<Record<string, any>> {
    if (!this.secretsClient) {
      throw new Error('AWS Secrets Manager client not initialized');
    }

    const cached = this.cache.get(`secret:${secretId}`);
    if (cached) return cached;

    try {
      const response = await this.secretsClient.send(
        new GetSecretValueCommand({ SecretId: secretId })
      );
      
      const secret = JSON.parse(response.SecretString || '{}');
      this.cache.set(`secret:${secretId}`, secret);
      return secret;
    } catch (error) {
      console.error(`Failed to fetch secret ${secretId}:`, error);
      throw error;
    }
  }

  getBaseConfig(): Config {
    return {
      NODE_ENV: this.get('NODE_ENV', 'development'),
      AWS_REGION: this.get('AWS_REGION', 'us-east-1'),
      SERVICE_NAME: this.get('SERVICE_NAME', 'unknown'),
      LOG_LEVEL: this.get('LOG_LEVEL', 'info'),
      PORT: this.getNumber('PORT', 3000),
    };
  }
}

export const configService = new ConfigService();
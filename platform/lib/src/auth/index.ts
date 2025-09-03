import {
  CognitoIdentityProviderClient,
  InitiateAuthCommand,
  SignUpCommand,
  ConfirmSignUpCommand,
  GetUserCommand,
  GlobalSignOutCommand,
  type UserAttributeType,
} from '@aws-sdk/client-cognito-identity-provider';
import { CognitoJwtVerifier } from 'aws-jwt-verify';

export interface User {
  id: string;
  email: string;
  emailVerified: boolean;
  roles: string[];
  createdAt: Date;
}

export interface AuthTokens {
  accessToken: string;
  refreshToken: string;
  idToken: string;
  expiresIn: number;
}

/**
 * AWS Cognito-based authentication service
 * Handles user authentication, token verification, and user management
 */
export class CognitoAuthService {
  private client: CognitoIdentityProviderClient;
  private userPoolId: string;
  private clientId: string;
  private verifier: ReturnType<typeof CognitoJwtVerifier.create>;

  constructor() {
    const region = process.env.AWS_REGION || 'us-east-1';
    this.userPoolId = process.env.COGNITO_USER_POOL_ID || '';
    this.clientId = process.env.COGNITO_CLIENT_ID || '';

    if (!this.userPoolId || !this.clientId) {
      throw new Error('Cognito User Pool ID and Client ID must be configured');
    }

    this.client = new CognitoIdentityProviderClient({ region });
    
    // JWT verifier for access tokens
    this.verifier = CognitoJwtVerifier.create({
      userPoolId: this.userPoolId,
      tokenUse: 'access',
      clientId: this.clientId,
    });
  }

  /**
   * Sign up a new user
   */
  async signUp(email: string, password: string): Promise<{ userId: string }> {
    const command = new SignUpCommand({
      ClientId: this.clientId,
      Username: email,
      Password: password,
      UserAttributes: [
        { Name: 'email', Value: email },
      ],
    });

    const response = await this.client.send(command);
    return { userId: response.UserSub! };
  }

  /**
   * Confirm user signup with verification code
   */
  async confirmSignUp(email: string, code: string): Promise<void> {
    const command = new ConfirmSignUpCommand({
      ClientId: this.clientId,
      Username: email,
      ConfirmationCode: code,
    });

    await this.client.send(command);
  }

  /**
   * Sign in user and get tokens
   */
  async signIn(email: string, password: string): Promise<AuthTokens> {
    const command = new InitiateAuthCommand({
      ClientId: this.clientId,
      AuthFlow: 'USER_PASSWORD_AUTH',
      AuthParameters: {
        USERNAME: email,
        PASSWORD: password,
      },
    });

    const response = await this.client.send(command);
    
    if (!response.AuthenticationResult) {
      throw new Error('Authentication failed');
    }

    return {
      accessToken: response.AuthenticationResult.AccessToken!,
      refreshToken: response.AuthenticationResult.RefreshToken!,
      idToken: response.AuthenticationResult.IdToken!,
      expiresIn: response.AuthenticationResult.ExpiresIn!,
    };
  }

  /**
   * Refresh tokens using refresh token
   */
  async refreshTokens(refreshToken: string): Promise<AuthTokens> {
    const command = new InitiateAuthCommand({
      ClientId: this.clientId,
      AuthFlow: 'REFRESH_TOKEN_AUTH',
      AuthParameters: {
        REFRESH_TOKEN: refreshToken,
      },
    });

    const response = await this.client.send(command);
    
    if (!response.AuthenticationResult) {
      throw new Error('Token refresh failed');
    }

    return {
      accessToken: response.AuthenticationResult.AccessToken!,
      refreshToken: refreshToken, // Refresh token doesn't change
      idToken: response.AuthenticationResult.IdToken!,
      expiresIn: response.AuthenticationResult.ExpiresIn!,
    };
  }

  /**
   * Verify and decode access token
   */
  async verifyAccessToken(token: string): Promise<any> {
    try {
      const payload = await this.verifier.verify(token);
      return payload;
    } catch (error) {
      throw new Error('Invalid or expired token');
    }
  }

  /**
   * Sign out user globally (invalidate all tokens)
   */
  async signOut(accessToken: string): Promise<void> {
    const command = new GlobalSignOutCommand({
      AccessToken: accessToken,
    });

    await this.client.send(command);
  }

  /**
   * Get user info from access token
   */
  async getUser(accessToken: string): Promise<User> {
    const command = new GetUserCommand({
      AccessToken: accessToken,
    });

    const response = await this.client.send(command);
    
    const attributes = response.UserAttributes?.reduce((acc: Record<string, string>, attr: UserAttributeType) => {
      if (attr.Name && attr.Value) {
        acc[attr.Name] = attr.Value;
      }
      return acc;
    }, {} as Record<string, string>) || {};

    return {
      id: response.Username!,
      email: attributes.email,
      emailVerified: attributes.email_verified === 'true',
      roles: (attributes['custom:roles'] || 'user').split(','),
      createdAt: new Date(response.UserCreateDate!),
    };
  }
}

export const cognitoAuth = new CognitoAuthService();
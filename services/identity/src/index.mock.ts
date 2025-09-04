import express from 'express';
import cors from 'cors';

const app = express();
const PORT = 3001;

app.use(cors());
app.use(express.json());

// Mock user data
let users = new Map();
let nextUserId = 1;

// Health check
app.get('/health', (req, res) => {
  res.json({ status: 'healthy', service: 'identity-service-mock' });
});

// Mock signup
app.post('/api/auth/signup', (req, res) => {
  const { email, password, firstName, lastName } = req.body;
  
  if (users.has(email)) {
    return res.status(409).json({ error: 'User already exists' });
  }
  
  const userId = `user_${nextUserId++}`;
  const user = {
    id: userId,
    email,
    firstName,
    lastName,
    status: 'PENDING_CONFIRMATION',
    createdAt: new Date().toISOString(),
  };
  
  users.set(email, { ...user, password });
  
  res.status(201).json({
    message: 'User created successfully. Please check your email for verification code.',
    userId,
    email,
  });
});

// Mock confirm (auto-confirms)
app.post('/api/auth/confirm', (req, res) => {
  const { email, code } = req.body;
  
  const user = users.get(email);
  if (!user) {
    return res.status(404).json({ error: 'User not found' });
  }
  
  user.status = 'ACTIVE';
  res.json({ message: 'Email confirmed successfully. You can now sign in.' });
});

// Mock signin
app.post('/api/auth/signin', (req, res) => {
  const { email, password } = req.body;
  
  const user = users.get(email);
  if (!user || user.password !== password) {
    return res.status(401).json({ error: 'Invalid credentials' });
  }
  
  if (user.status !== 'ACTIVE') {
    return res.status(400).json({ error: 'User email not confirmed' });
  }
  
  // Generate mock tokens
  const mockToken = Buffer.from(JSON.stringify({ 
    sub: user.id, 
    email: user.email 
  })).toString('base64');
  
  res.json({
    accessToken: `mock_access_${mockToken}`,
    refreshToken: `mock_refresh_${mockToken}`,
    idToken: `mock_id_${mockToken}`,
    expiresIn: 3600,
  });
});

// Mock get user
app.get('/api/users/me', (req, res) => {
  const authHeader = req.headers.authorization;
  if (!authHeader) {
    return res.status(401).json({ error: 'No token provided' });
  }
  
  try {
    const token = authHeader.replace('Bearer mock_access_', '');
    const decoded = JSON.parse(Buffer.from(token, 'base64').toString());
    
    const user = Array.from(users.values()).find(u => u.id === decoded.sub);
    if (!user) {
      return res.status(404).json({ error: 'User not found' });
    }
    
    const { password, ...userWithoutPassword } = user;
    res.json(userWithoutPassword);
  } catch (error) {
    res.status(401).json({ error: 'Invalid token' });
  }
});

// Mock signout
app.post('/api/auth/signout', (req, res) => {
  res.json({ message: 'Signed out successfully' });
});

app.listen(PORT, () => {
  console.log(`Mock Identity Service running on http://localhost:${PORT}`);
  console.log('Health check: http://localhost:3001/health');
  console.log('\nThis is a MOCK service for testing without AWS Cognito/DynamoDB');
  console.log('Use any email/password combination for testing');
});

export { app };
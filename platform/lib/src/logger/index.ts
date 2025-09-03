import winston from 'winston';

const { combine, timestamp, json, errors, printf } = winston.format;

const logLevel = process.env.LOG_LEVEL || 'info';

const developmentFormat = printf(({ level, message, timestamp, ...metadata }) => {
  let msg = `${timestamp} [${level.toUpperCase()}]: ${message}`;
  if (Object.keys(metadata).length > 0) {
    msg += ` ${JSON.stringify(metadata)}`;
  }
  return msg;
});

const createLogger = (service: string) => {
  const isProd = process.env.NODE_ENV === 'production';
  
  return winston.createLogger({
    level: logLevel,
    defaultMeta: { service },
    format: combine(
      errors({ stack: true }),
      timestamp(),
      isProd ? json() : developmentFormat
    ),
    transports: [
      new winston.transports.Console({
        stderrLevels: ['error'],
      }),
    ],
  });
};

export { createLogger };
export type Logger = ReturnType<typeof createLogger>;
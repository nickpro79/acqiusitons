import 'dotenv/config';

import {neon, neonConfig} from '@neondatabase/serverless';
import {drizzle} from 'drizzle-orm/neon-http';

// Configure Neon for local development with Neon Local
if (process.env.NODE_ENV === 'development') {

  neonConfig.fetchEndpoint = `http://neon-local:5432/sql`;
  neonConfig.useSecureWebSocket = false;
  neonConfig.poolQueryViaFetch = true;
}

export const sql = neon(process.env.DATABASE_URL)

export const db = drizzle(sql);

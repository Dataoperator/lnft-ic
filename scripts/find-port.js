import { createServer } from 'net';
import { readFileSync, writeFileSync } from 'fs';
import { join } from 'path';
import { fileURLToPath } from 'url';
import { dirname } from 'path';

const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);

// Function to check if a port is available
function isPortAvailable(port) {
  return new Promise((resolve) => {
    const server = createServer();
    
    server.once('error', () => {
      resolve(false);
    });

    server.once('listening', () => {
      server.close();
      resolve(true);
    });

    server.listen(port, '127.0.0.1');
  });
}

// Function to find next available port
async function findAvailablePort(startPort = 8001) {
  let port = startPort;
  while (!(await isPortAvailable(port))) {
    port++;
    if (port > 65535) {
      throw new Error('No available ports found');
    }
  }
  return port;
}

// Main function to update dfx.json
export async function updateDfxJson() {
  try {
    const dfxPath = join(process.cwd(), 'dfx.json');
    const dfxConfig = JSON.parse(readFileSync(dfxPath, 'utf8'));
    
    // Find available port
    const port = await findAvailablePort();
    
    // Update dfx.json
    dfxConfig.networks = {
      ...dfxConfig.networks,
      local: {
        ...dfxConfig.networks.local,
        bind: `127.0.0.1:${port}`,
        type: "ephemeral"
      }
    };

    // Write updated config
    writeFileSync(dfxPath, JSON.stringify(dfxConfig, null, 2));
    console.log(`Updated dfx.json to use port ${port}`);
    
    // Return the port for use in scripts
    return port;
  } catch (error) {
    console.error('Error updating dfx.json:', error);
    process.exit(1);
  }
}

// Run if called directly
if (import.meta.url === `file://${process.argv[1]}`) {
  updateDfxJson();
}
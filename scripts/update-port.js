import { updateDfxJson } from './find-port.js';

async function main() {
  try {
    await updateDfxJson();
    process.exit(0);
  } catch (error) {
    console.error('Failed to update port:', error);
    process.exit(1);
  }
}

main();
// Action Cable provides the framework to deal with WebSockets in Rails.
// You can generate new channels where WebSocket features live using the `bin/rails generate channel` command.

import { createConsumer } from "@rails/actioncable"

// export default createConsumer()

// ngrok用に動的にURLを設定
const cableUrl = window.location.hostname.includes('ngrok') 
  ? `wss://${window.location.hostname}/cable`
  : 'ws://localhost:3000/cable';
export default createConsumer(cableUrl);
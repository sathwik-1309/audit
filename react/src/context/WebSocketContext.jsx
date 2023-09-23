// WebSocketContext.js
import React, { createContext, useContext, useState, useEffect } from 'react';
import { BACKEND_API_URL, HOST_IP, RAILS_PORT } from '../config';

const WebSocketContext = createContext();

export function WebSocketProvider({ children }) {
  const [webSocket, setWebSocket] = useState(null);

  useEffect(() => {
    const socket_url = `ws://${HOST_IP}:${RAILS_PORT}/cable`
    const socket = new WebSocket(socket_url);

    socket.onopen = () => {
      console.log('WebSocket connection established');
      setWebSocket(socket);
    };

    socket.onclose = () => {
      console.log('WebSocket connection closed');
      setWebSocket(null);
    };

    return () => {
      if (webSocket) {
        webSocket.close();
      }
    };
  }, []);

  return (
    <WebSocketContext.Provider value={webSocket}>
      {children}
    </WebSocketContext.Provider>
  );
}

export function refreshWebSocket(channel, counter, setCounter) {
  const webSocket = useContext(WebSocketContext);

  useEffect(() => {
    if (!webSocket) return;

    const handleWebSocketMessage = (event) => {
      if (event.data === undefined) {return}
      const data = JSON.parse(event.data);
      if (data.type === 'ping') {return}
      console.log(data)
      if (JSON.parse(data.identifier).channel === channel) {
        setCounter(counter++)
      }
    };

    const msg = {
      command: "subscribe",
      identifier: JSON.stringify({
        id: 1,
        channel: channel
      })
    }
    webSocket.send(JSON.stringify(msg));

    webSocket.addEventListener('message', handleWebSocketMessage);

  }, [webSocket, counter]);
}


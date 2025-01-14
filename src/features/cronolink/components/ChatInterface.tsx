import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { EmotionalState, Memory } from '../../../types/canister';
import { CronolinkStore } from '../cronolink.store';

interface Message {
  id: string;
  sender: 'user' | 'lnft';
  content: string;
  timestamp: number;
}

interface ChatInterfaceProps {
  lnftId: string;
  onEmotionalUpdate?: (update: EmotionalState) => void;
  onNewMemory?: (memory: Memory) => void;
}

export const ChatInterface: React.FC<ChatInterfaceProps> = ({
  lnftId,
  onEmotionalUpdate,
  onNewMemory,
}) => {
  const [message, setMessage] = useState('');
  const [messages, setMessages] = useState<Message[]>([]);
  const [isProcessing, setIsProcessing] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const messagesEndRef = useRef<HTMLDivElement>(null);
  const cronolinkStore = new CronolinkStore();

  const scrollToBottom = () => {
    messagesEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  };

  useEffect(() => {
    scrollToBottom();
  }, [messages]);

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!message.trim() || isProcessing) return;

    const newUserMessage: Message = {
      id: `user-${Date.now()}`,
      sender: 'user',
      content: message.trim(),
      timestamp: Date.now(),
    };

    setMessages(prev => [...prev, newUserMessage]);
    setMessage('');
    setIsProcessing(true);
    setError(null);

    try {
      const result = await cronolinkStore.processMessage(lnftId, newUserMessage.content);
      
      const newLNFTMessage: Message = {
        id: `lnft-${Date.now()}`,
        sender: 'lnft',
        content: result.response,
        timestamp: Date.now(),
      };

      setMessages(prev => [...prev, newLNFTMessage]);
      
      if (result.emotionalUpdate && onEmotionalUpdate) {
        onEmotionalUpdate(result.emotionalUpdate);
      }
      
      if (result.newMemory && onNewMemory) {
        onNewMemory(result.newMemory);
      }
    } catch (err) {
      setError(err instanceof Error ? err.message : 'An error occurred while processing your message');
      console.error('Error processing message:', err);
    } finally {
      setIsProcessing(false);
    }
  };

  return (
    <div className="flex flex-col h-[600px] bg-black/90 rounded-lg border border-cyan-500/30">
      <div className="flex-1 overflow-y-auto p-4 space-y-4">
        <AnimatePresence initial={false}>
          {messages.map((msg) => (
            <motion.div
              key={msg.id}
              initial={{ opacity: 0, y: 20 }}
              animate={{ opacity: 1, y: 0 }}
              exit={{ opacity: 0 }}
              className={`flex ${msg.sender === 'user' ? 'justify-end' : 'justify-start'}`}
            >
              <motion.div
                initial={{ scale: 0.95 }}
                animate={{ scale: 1 }}
                className={`max-w-[80%] p-3 rounded-lg ${
                  msg.sender === 'user'
                    ? 'bg-cyan-500/20 text-cyan-50'
                    : 'bg-purple-500/20 text-purple-50'
                }`}
              >
                {msg.content}
                <div className="text-xs mt-1 opacity-50">
                  {new Date(msg.timestamp).toLocaleTimeString()}
                </div>
              </motion.div>
            </motion.div>
          ))}
        </AnimatePresence>
        {error && (
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            className="text-red-400 text-sm text-center p-2 bg-red-500/10 rounded"
          >
            {error}
          </motion.div>
        )}
        <div ref={messagesEndRef} />
      </div>

      <form onSubmit={handleSubmit} className="p-4 border-t border-cyan-500/30">
        <div className="flex space-x-2">
          <input
            type="text"
            value={message}
            onChange={(e) => setMessage(e.target.value)}
            disabled={isProcessing}
            placeholder={isProcessing ? "Processing..." : "Type your message..."}
            className="flex-1 bg-black/50 text-white border border-cyan-500/30 rounded-lg px-4 py-2 
                     focus:outline-none focus:border-cyan-500 placeholder-cyan-500/50
                     disabled:opacity-50 disabled:cursor-not-allowed"
            maxLength={500}
          />
          <motion.button
            type="submit"
            disabled={isProcessing || !message.trim()}
            whileHover={{ scale: 1.02 }}
            whileTap={{ scale: 0.98 }}
            className="bg-cyan-500 hover:bg-cyan-600 disabled:bg-cyan-500/50 text-white px-6 py-2 
                     rounded-lg transition-colors duration-200 disabled:cursor-not-allowed
                     flex items-center"
          >
            {isProcessing ? (
              <span className="flex items-center">
                <motion.span
                  animate={{ rotate: 360 }}
                  transition={{ duration: 1, repeat: Infinity, ease: "linear" }}
                  className="mr-2"
                >
                  ⚡
                </motion.span>
              </span>
            ) : (
              'Send'
            )}
          </motion.button>
        </div>
        <div className="text-xs text-cyan-500/50 mt-2">
          {500 - message.length} characters remaining
        </div>
      </form>
    </div>
  );
};
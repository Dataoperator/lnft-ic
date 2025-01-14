import React, { useState, useEffect, useRef } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useCronolinkStore } from '../cronolink.store';
import { EmotionalState } from '../../../types';
import { MatrixText } from '../../../components/MatrixText';

interface ChatInterfaceProps {
  lnftId: string;
}

export const ChatInterface: React.FC<ChatInterfaceProps> = ({ lnftId }) => {
  const { 
    messages,
    currentEmotionalState,
    isLoading,
    error,
    sendMessage,
    fetchEmotionalState,
    fetchMemories 
  } = useCronolinkStore();

  const [input, setInput] = useState('');
  const chatEndRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    fetchEmotionalState(lnftId);
    fetchMemories(lnftId);
  }, [lnftId]);

  useEffect(() => {
    chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
  }, [messages]);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim()) return;

    await sendMessage(lnftId, input.trim());
    setInput('');
  };

  const getEmotionColor = (emotion: EmotionalState) => {
    const intensityScale = Math.min(Math.max(emotion.intensity / 100, 0), 1);
    switch (emotion.mood.toLowerCase()) {
      case 'happy':
        return `rgba(0, 255, 159, ${intensityScale})`; // cyber-neon
      case 'sad':
        return `rgba(0, 255, 255, ${intensityScale})`; // cyber-blue
      case 'angry':
        return `rgba(255, 0, 255, ${intensityScale})`; // cyber-pink
      case 'neutral':
        return `rgba(255, 255, 0, ${intensityScale})`; // cyber-yellow
      default:
        return `rgba(0, 255, 159, ${intensityScale})`; // cyber-neon
    }
  };

  return (
    <div className="flex flex-col h-[600px] bg-cyber-darker/80 rounded-lg overflow-hidden border border-cyber-neon/30">
      {/* Emotional State Display */}
      <AnimatePresence>
        {currentEmotionalState && (
          <motion.div 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="p-2 text-sm font-mono text-center"
            style={{ 
              backgroundColor: `${getEmotionColor(currentEmotionalState)}20`,
              borderBottom: `1px solid ${getEmotionColor(currentEmotionalState)}40`
            }}
          >
            <span className="text-cyber-neon">
              EMOTIONAL_STATE: {currentEmotionalState.mood.toUpperCase()} 
              <span className="ml-2 text-cyber-neon/70">
                [INTENSITY: {currentEmotionalState.intensity}%]
              </span>
            </span>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Chat Messages */}
      <div className="flex-1 overflow-y-auto p-4 space-y-4 scrollbar-cyber">
        <AnimatePresence>
          {messages.map(message => (
            <motion.div 
              key={message.id}
              initial={{ opacity: 0, x: message.sender === 'user' ? 20 : -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: message.sender === 'user' ? 20 : -20 }}
              className={`flex ${message.sender === 'user' ? 'justify-end' : 'justify-start'}`}
            >
              <div
                className={`max-w-[70%] rounded-lg p-3 font-mono ${
                  message.sender === 'user'
                    ? 'bg-cyber-neon/20 border border-cyber-neon/30 text-cyber-neon'
                    : 'bg-cyber-darker/90 border border-cyber-blue/30 text-cyber-blue'
                }`}
              >
                <p className="text-sm">{message.content}</p>
                {message.emotionalState && (
                  <div 
                    className="mt-1 text-xs opacity-75"
                    style={{ color: getEmotionColor(message.emotionalState) }}
                  >
                    {`<mood=${message.emotionalState.mood.toLowerCase()} />`}
                  </div>
                )}
              </div>
            </motion.div>
          ))}
        </AnimatePresence>
        <div ref={chatEndRef} />
      </div>

      {/* Error Display */}
      <AnimatePresence>
        {error && (
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 20 }}
            className="p-2 text-sm font-mono text-center text-cyber-pink bg-cyber-pink/20 border-t border-cyber-pink/30"
          >
            {`ERROR: ${error}`}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Input Form */}
      <form onSubmit={handleSend} className="p-4 bg-cyber-darker/90 border-t border-cyber-neon/30">
        <div className="flex space-x-2">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder="ENTER_COMMAND://"
            className="flex-1 px-4 py-2 bg-cyber-dark/90 text-cyber-neon font-mono border border-cyber-neon/30 rounded-lg 
                     focus:outline-none focus:border-cyber-neon focus:ring-1 focus:ring-cyber-neon/50 placeholder-cyber-neon/30"
            disabled={isLoading}
          />
          <motion.button
            type="submit"
            disabled={isLoading}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className={`px-6 py-2 font-mono text-cyber-dark bg-cyber-neon/90 rounded-lg
                       border border-cyber-neon transition-colors duration-200
                       ${isLoading ? 'opacity-50 cursor-not-allowed' : 'hover:bg-cyber-neon'}`}
          >
            {isLoading ? (
              <span className="inline-flex items-center">
                <svg className="w-4 h-4 mr-2 animate-spin" viewBox="0 0 24 24">
                  <circle
                    className="opacity-25"
                    cx="12"
                    cy="12"
                    r="10"
                    stroke="currentColor"
                    strokeWidth="4"
                    fill="none"
                  />
                  <path
                    className="opacity-75"
                    fill="currentColor"
                    d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"
                  />
                </svg>
                PROCESSING...
              </span>
            ) : (
              'TRANSMIT'
            )}
          </motion.button>
        </div>
      </form>
    </div>
  );
};
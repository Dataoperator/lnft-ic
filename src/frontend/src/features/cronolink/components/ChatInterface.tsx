import React, { useState, useEffect, useRef, useCallback } from 'react';
import { motion, AnimatePresence } from 'framer-motion';
import { useCronolinkStore } from '../cronolink.store';
import { EmotionalState } from '../../../types/canister';
import { MatrixText } from '../../../components/MatrixText';
import { useAuthStore } from '../../auth/auth.store';

interface ChatInterfaceProps {
  lnftId: string;
  className?: string;
}

const NEURAL_RESPONSES = [
  "Establishing neural connection...",
  "Processing cognitive patterns...",
  "Analyzing emotional matrix...",
  "Synchronizing memory banks...",
  "Calculating response vectors..."
];

export const ChatInterface: React.FC<ChatInterfaceProps> = ({ 
  lnftId,
  className = ''
}) => {
  const { 
    messages,
    currentEmotionalState,
    isLoading,
    error,
    sendMessage,
    fetchEmotionalState,
    fetchMemories,
    clearChat
  } = useCronolinkStore();

  const { isAuthenticated } = useAuthStore();

  const [input, setInput] = useState('');
  const [loadingMessage, setLoadingMessage] = useState('');
  const chatEndRef = useRef<HTMLDivElement>(null);
  const chatContainerRef = useRef<HTMLDivElement>(null);
  const [isAtBottom, setIsAtBottom] = useState(true);

  useEffect(() => {
    if (!isAuthenticated) {
      clearChat();
      return;
    }

    fetchEmotionalState(lnftId);
    fetchMemories(lnftId);
  }, [lnftId, isAuthenticated]);

  // Loading message animation
  useEffect(() => {
    if (!isLoading) {
      setLoadingMessage('');
      return;
    }

    let currentIndex = 0;
    const interval = setInterval(() => {
      setLoadingMessage(NEURAL_RESPONSES[currentIndex]);
      currentIndex = (currentIndex + 1) % NEURAL_RESPONSES.length;
    }, 1500);

    return () => clearInterval(interval);
  }, [isLoading]);

  // Scroll handling
  const handleScroll = useCallback(() => {
    if (!chatContainerRef.current) return;
    
    const { scrollTop, scrollHeight, clientHeight } = chatContainerRef.current;
    const isBottom = Math.abs(scrollHeight - clientHeight - scrollTop) < 50;
    setIsAtBottom(isBottom);
  }, []);

  useEffect(() => {
    const chatContainer = chatContainerRef.current;
    if (chatContainer) {
      chatContainer.addEventListener('scroll', handleScroll);
      return () => chatContainer.removeEventListener('scroll', handleScroll);
    }
  }, [handleScroll]);

  useEffect(() => {
    if (isAtBottom) {
      chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
    }
  }, [messages, isAtBottom]);

  const handleSend = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!input.trim() || !isAuthenticated) return;

    try {
      await sendMessage(lnftId, input.trim());
      setInput('');
      setIsAtBottom(true);
    } catch (error) {
      // Error handled by store
    }
  };

  const getEmotionColor = (emotion: EmotionalState) => {
    const intensityScale = Math.min(Math.max(emotion.intensity / 100, 0), 1);
    const baseColor = 
      emotion.primary === 'joy' ? 'cyber-neon' :
      emotion.primary === 'sorrow' ? 'cyber-blue' :
      emotion.primary === 'anger' ? 'cyber-pink' :
      emotion.primary === 'fear' ? 'cyber-yellow' :
      'cyber-neon';

    return `var(--${baseColor})${Math.round(intensityScale * 100)}`;
  };

  return (
    <div className={`flex flex-col h-[600px] bg-cyber-darker/80 rounded-lg 
                     overflow-hidden border border-cyber-neon/30 ${className}`}>
      {/* Emotional State Display */}
      <AnimatePresence mode="wait">
        {currentEmotionalState && (
          <motion.div 
            initial={{ opacity: 0, y: -20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: -20 }}
            className="p-2 text-sm font-mono text-center border-b"
            style={{ 
              backgroundColor: `${getEmotionColor(currentEmotionalState)}20`,
              borderColor: `${getEmotionColor(currentEmotionalState)}40`
            }}
          >
            <span className="text-cyber-neon">
              EMOTIONAL_STATE: {currentEmotionalState.primary.toUpperCase()} 
              <span className="ml-2 text-cyber-neon/70">
                [INTENSITY: {currentEmotionalState.intensity}%]
              </span>
            </span>
          </motion.div>
        )}
      </AnimatePresence>

      {/* Chat Messages */}
      <div 
        ref={chatContainerRef}
        className="flex-1 overflow-y-auto p-4 space-y-4 scrollbar-cyber"
      >
        <AnimatePresence mode="sync">
          {messages.map((message) => (
            <motion.div 
              key={message.id}
              initial={{ opacity: 0, x: message.sender === 'user' ? 20 : -20 }}
              animate={{ opacity: 1, x: 0 }}
              exit={{ opacity: 0, x: message.sender === 'user' ? 20 : -20 }}
              className={`flex ${message.sender === 'user' ? 'justify-end' : 'justify-start'}`}
            >
              <div
                className={`max-w-[70%] rounded-lg p-3 font-mono 
                           backdrop-blur-sm transition-all duration-200
                           ${message.sender === 'user'
                             ? 'bg-cyber-neon/20 border border-cyber-neon/30 text-cyber-neon hover:bg-cyber-neon/30'
                             : 'bg-cyber-darker/90 border border-cyber-blue/30 text-cyber-blue hover:bg-cyber-darker'
                           }`}
              >
                <p className="text-sm whitespace-pre-wrap">{message.content}</p>
                {message.emotionalState && (
                  <div 
                    className="mt-1 text-xs opacity-75"
                    style={{ color: getEmotionColor(message.emotionalState) }}
                  >
                    {`<emotion="${message.emotionalState.primary}" intensity="${message.emotionalState.intensity}" />`}
                  </div>
                )}
              </div>
            </motion.div>
          ))}

          {/* Loading Message */}
          <AnimatePresence mode="wait">
            {isLoading && loadingMessage && (
              <motion.div
                initial={{ opacity: 0, x: -20 }}
                animate={{ opacity: 1, x: 0 }}
                exit={{ opacity: 0, x: -20 }}
                className="flex justify-start"
              >
                <div className="max-w-[70%] rounded-lg p-3 font-mono 
                               bg-cyber-darker/90 border border-cyber-blue/30 text-cyber-blue/70">
                  <p className="text-sm">{loadingMessage}</p>
                </div>
              </motion.div>
            )}
          </AnimatePresence>
        </AnimatePresence>
        <div ref={chatEndRef} />
      </div>

      {/* Scroll to Bottom Button */}
      <AnimatePresence>
        {!isAtBottom && messages.length > 0 && (
          <motion.button
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 20 }}
            onClick={() => {
              setIsAtBottom(true);
              chatEndRef.current?.scrollIntoView({ behavior: 'smooth' });
            }}
            className="absolute bottom-20 right-4 p-2 rounded-full bg-cyber-darker 
                       border border-cyber-neon text-cyber-neon hover:bg-cyber-neon/20
                       transition-colors duration-200"
          >
            <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} 
                    d="M19 14l-7 7m0 0l-7-7m7 7V3" 
              />
            </svg>
          </motion.button>
        )}
      </AnimatePresence>

      {/* Error Display */}
      <AnimatePresence>
        {error && (
          <motion.div 
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            exit={{ opacity: 0, y: 20 }}
            className="p-2 text-sm font-mono text-center text-cyber-pink 
                      bg-cyber-pink/20 border-t border-cyber-pink/30"
          >
            {`ERROR: ${error}`}
          </motion.div>
        )}
      </AnimatePresence>

      {/* Input Form */}
      <form 
        onSubmit={handleSend} 
        className="p-4 bg-cyber-darker/90 border-t border-cyber-neon/30"
      >
        <div className="flex space-x-2">
          <input
            type="text"
            value={input}
            onChange={(e) => setInput(e.target.value)}
            placeholder={isAuthenticated ? "ENTER_MESSAGE://" : "NEURAL_LINK_REQUIRED://"}
            className="flex-1 px-4 py-2 bg-cyber-dark/90 text-cyber-neon font-mono 
                     border border-cyber-neon/30 rounded-lg placeholder-cyber-neon/30
                     focus:outline-none focus:border-cyber-neon focus:ring-1 
                     focus:ring-cyber-neon/50 disabled:opacity-50
                     disabled:cursor-not-allowed"
            disabled={isLoading || !isAuthenticated}
          />
          <motion.button
            type="submit"
            disabled={isLoading || !isAuthenticated}
            whileHover={{ scale: 1.05 }}
            whileTap={{ scale: 0.95 }}
            className={`px-6 py-2 font-mono text-cyber-dark bg-cyber-neon/90 rounded-lg
                       border border-cyber-neon transition-all duration-200
                       disabled:opacity-50 disabled:cursor-not-allowed
                       ${isLoading 
                         ? 'opacity-50 cursor-not-allowed' 
                         : 'hover:bg-cyber-neon hover:shadow-lg hover:shadow-cyber-neon/20'}`}
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
                PROCESSING
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
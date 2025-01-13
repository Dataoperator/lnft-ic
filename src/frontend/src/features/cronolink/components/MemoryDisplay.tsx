import React from 'react';
import { useCronolinkStore } from '../cronolink.store';
import { Memory, MemoryType } from '../../../types';

interface MemoryDisplayProps {
  lnftId: string;
}

export const MemoryDisplay: React.FC<MemoryDisplayProps> = ({ lnftId }) => {
  const { memories } = useCronolinkStore();

  const getMemoryIcon = (type: MemoryType) => {
    switch (type) {
      case MemoryType.Interaction:
        return (
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 10h.01M12 10h.01M16 10h.01M9 16H5a2 2 0 01-2-2V6a2 2 0 012-2h14a2 2 0 012 2v8a2 2 0 01-2 2h-4l-4 4-4-4z" />
          </svg>
        );
      case MemoryType.Achievement:
        return (
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9 12l2 2 4-4M7.835 4.697a3.42 3.42 0 001.946-.806 3.42 3.42 0 014.438 0 3.42 3.42 0 001.946.806 3.42 3.42 0 013.138 3.138 3.42 3.42 0 00.806 1.946 3.42 3.42 0 010 4.438 3.42 3.42 0 00-.806 1.946 3.42 3.42 0 01-3.138 3.138 3.42 3.42 0 00-1.946.806 3.42 3.42 0 01-4.438 0 3.42 3.42 0 00-1.946-.806 3.42 3.42 0 01-3.138-3.138 3.42 3.42 0 00-.806-1.946 3.42 3.42 0 010-4.438 3.42 3.42 0 00.806-1.946 3.42 3.42 0 013.138-3.138z" />
          </svg>
        );
      case MemoryType.Event:
        return (
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z" />
          </svg>
        );
      case MemoryType.Skill:
        return (
          <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M9.663 17h4.673M12 3v1m6.364 1.636l-.707.707M21 12h-1M4 12H3m3.343-5.657l-.707-.707m2.828 9.9a5 5 0 117.072 0l-.548.547A3.374 3.374 0 0014 18.469V19a2 2 0 11-4 0v-.531c0-.895-.356-1.754-.988-2.386l-.548-.547z" />
          </svg>
        );
    }
  };

  const getMemoryColor = (type: MemoryType) => {
    switch (type) {
      case MemoryType.Interaction:
        return 'bg-blue-100 text-blue-800';
      case MemoryType.Achievement:
        return 'bg-green-100 text-green-800';
      case MemoryType.Event:
        return 'bg-purple-100 text-purple-800';
      case MemoryType.Skill:
        return 'bg-yellow-100 text-yellow-800';
    }
  };

  const formatTimestamp = (timestamp: number) => {
    return new Date(timestamp).toLocaleDateString('en-US', {
      month: 'short',
      day: 'numeric',
      year: 'numeric',
      hour: '2-digit',
      minute: '2-digit'
    });
  };

  return (
    <div className="bg-white rounded-lg shadow overflow-hidden">
      <div className="p-4 bg-gray-50 border-b border-gray-200">
        <h3 className="text-lg font-medium text-gray-900">Memories</h3>
      </div>
      <div className="divide-y divide-gray-200 max-h-96 overflow-y-auto">
        {memories.map((memory) => (
          <div key={memory.id} className="p-4 hover:bg-gray-50">
            <div className="flex items-center space-x-3">
              <div className={`p-2 rounded-lg ${getMemoryColor(memory.type)}`}>
                {getMemoryIcon(memory.type)}
              </div>
              <div className="flex-1 min-w-0">
                <p className="text-sm font-medium text-gray-900">
                  {memory.content}
                </p>
                <p className="text-sm text-gray-500">
                  {formatTimestamp(memory.timestamp)}
                </p>
              </div>
              <div className="flex items-center">
                <span 
                  className={`inline-flex items-center px-2.5 py-0.5 rounded-full text-xs font-medium ${
                    memory.emotionalImpact > 0 ? 'bg-green-100 text-green-800' : 'bg-red-100 text-red-800'
                  }`}
                >
                  Impact: {memory.emotionalImpact > 0 ? '+' : ''}{memory.emotionalImpact}
                </span>
              </div>
            </div>
          </div>
        ))}
        {memories.length === 0 && (
          <div className="p-4 text-center text-gray-500">
            No memories stored yet
          </div>
        )}
      </div>
    </div>
  );
};
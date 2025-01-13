import React, { useState } from 'react';
import { MintingInterface } from '../minting/components/MintingInterface';
import { ChatInterface } from '../cronolink/components/ChatInterface';
import { MemoryDisplay } from '../cronolink/components/MemoryDisplay';
import { LoginButton } from '../auth/components/LoginButton';

export const DashboardView: React.FC = () => {
  const [selectedLNFT, setSelectedLNFT] = useState<string | null>(null);

  return (
    <div className="min-h-screen bg-gray-100">
      <header className="bg-white shadow">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-6 flex justify-between items-center">
          <div className="flex items-center">
            <h1 className="text-3xl font-bold text-gray-900">LNFT Dashboard</h1>
          </div>
          <LoginButton />
        </div>
      </header>

      <main className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
        <div className="grid grid-cols-1 gap-8 lg:grid-cols-2">
          {/* Left Column */}
          <div className="space-y-8">
            <div className="bg-white rounded-lg shadow">
              <div className="p-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-4">Your LNFTs</h2>
                {selectedLNFT ? (
                  <div className="space-y-4">
                    <MemoryDisplay lnftId={selectedLNFT} />
                  </div>
                ) : (
                  <div className="text-center py-12">
                    <h3 className="text-lg font-medium text-gray-900 mb-2">No LNFT Selected</h3>
                    <p className="text-sm text-gray-500">Select an LNFT to view its details</p>
                  </div>
                )}
              </div>
            </div>
            
            <div className="bg-white rounded-lg shadow">
              <div className="p-6">
                <h2 className="text-xl font-semibold text-gray-900 mb-4">Mint New LNFT</h2>
                <MintingInterface />
              </div>
            </div>
          </div>

          {/* Right Column */}
          <div className="space-y-8">
            {selectedLNFT ? (
              <div className="bg-white rounded-lg shadow">
                <div className="p-6">
                  <h2 className="text-xl font-semibold text-gray-900 mb-4">Cronolink Interface</h2>
                  <ChatInterface lnftId={selectedLNFT} />
                </div>
              </div>
            ) : (
              <div className="bg-white rounded-lg shadow p-6">
                <div className="text-center py-12">
                  <h3 className="text-lg font-medium text-gray-900 mb-2">No Active Cronolink</h3>
                  <p className="text-sm text-gray-500">Select an LNFT to start a conversation</p>
                </div>
              </div>
            )}

            {selectedLNFT && (
              <div className="bg-white rounded-lg shadow">
                <div className="p-6">
                  <h2 className="text-xl font-semibold text-gray-900 mb-4">LNFT Stats</h2>
                  <div className="grid grid-cols-2 gap-4">
                    <div className="bg-gray-50 p-4 rounded-lg">
                      <h3 className="text-sm font-medium text-gray-500">Emotional State</h3>
                      <div className="mt-2 flex items-center">
                        <div className="flex-1">
                          <div className="w-full bg-gray-200 rounded-full h-2">
                            <div
                              className="bg-blue-600 h-2 rounded-full"
                              style={{ width: '70%' }}
                            />
                          </div>
                        </div>
                        <span className="ml-2 text-sm text-gray-900">70%</span>
                      </div>
                    </div>
                    <div className="bg-gray-50 p-4 rounded-lg">
                      <h3 className="text-sm font-medium text-gray-500">Memory Count</h3>
                      <p className="mt-1 text-2xl font-semibold text-gray-900">24</p>
                    </div>
                    <div className="bg-gray-50 p-4 rounded-lg">
                      <h3 className="text-sm font-medium text-gray-500">Skills</h3>
                      <p className="mt-1 text-2xl font-semibold text-gray-900">8</p>
                    </div>
                    <div className="bg-gray-50 p-4 rounded-lg">
                      <h3 className="text-sm font-medium text-gray-500">Achievements</h3>
                      <p className="mt-1 text-2xl font-semibold text-gray-900">12</p>
                    </div>
                  </div>
                </div>
              </div>
            )}
          </div>
        </div>
      </main>
    </div>
  );
};
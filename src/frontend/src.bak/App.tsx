import { type FC } from 'react';
import { MatrixRain } from './components/MatrixRain';

const App: FC = () => {
  return (
    <div className="relative min-h-screen">
      <MatrixRain />
      <div className="relative z-10 flex min-h-screen items-center justify-center">
        <h1 className="text-4xl font-mono text-[#00ff9f] font-bold">
          Digital Entities Test
        </h1>
      </div>
    </div>
  );
};

export default App;
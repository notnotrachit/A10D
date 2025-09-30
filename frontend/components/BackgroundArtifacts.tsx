export function BackgroundArtifacts() {
  return (
    <div className="pointer-events-none fixed inset-0 z-0 overflow-hidden">
      {/* Large floating circles */}
      <div className="absolute left-[12%] top-[-8rem] h-64 w-64 rounded-full border-2 border-white/20 animate-float-slow" />
      <div className="absolute bottom-[-10rem] left-[20%] h-80 w-80 rounded-full border border-white/15 animate-float-slower" />
      <div className="absolute left-[40%] top-[35%] h-40 w-40 rounded-full border border-white/25 animate-float-medium" />
      
      {/* Geometric shapes */}
      <div className="absolute right-[18%] top-[12%] h-48 w-48 rotate-45 border-2 border-white/20 animate-float-medium" />
      <div className="absolute bottom-[15%] right-[8%] h-56 w-56 rounded-[3rem] border border-white/15 animate-float-fast" />
      
      {/* Grid pattern overlay */}
      <div className="absolute inset-0 opacity-[0.03]" style={{
        backgroundImage: `
          linear-gradient(rgba(255,255,255,0.1) 1px, transparent 1px),
          linear-gradient(90deg, rgba(255,255,255,0.1) 1px, transparent 1px)
        `,
        backgroundSize: '60px 60px'
      }} />
      
      {/* Subtle radial gradients */}
      <div className="absolute left-[10%] top-[20%] h-96 w-96 rounded-full bg-gradient-radial from-white/5 to-transparent animate-pulse" style={{animationDuration: '8s'}} />
      <div className="absolute right-[15%] bottom-[25%] h-72 w-72 rounded-full bg-gradient-radial from-white/3 to-transparent animate-pulse" style={{animationDuration: '12s'}} />
    </div>
  );
}

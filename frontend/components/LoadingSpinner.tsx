export function LoadingSpinner({ size = 'md', className = '' }: { size?: 'sm' | 'md' | 'lg'; className?: string }) {
  const sizeClasses = {
    sm: 'h-4 w-4',
    md: 'h-6 w-6',
    lg: 'h-8 w-8'
  };

  return (
    <div className={`${sizeClasses[size]} animate-spin rounded-full border-2 border-current/20 border-t-current/60 ${className}`} />
  );
}

export function LoadingCard() {
  return (
    <div className="flex h-full flex-col justify-between rounded-xl border border-white/12 bg-slate-950/60 p-6 animate-pulse">
      <div className="space-y-4">
        <div className="flex items-center justify-between">
          <div className="h-3 w-16 bg-white/10 rounded" />
          <div className="h-3 w-12 bg-white/10 rounded" />
        </div>
        <div className="h-6 w-3/4 bg-white/10 rounded" />
        <div className="space-y-2">
          <div className="h-4 w-full bg-white/10 rounded" />
          <div className="h-4 w-2/3 bg-white/10 rounded" />
          <div className="h-4 w-1/2 bg-white/10 rounded" />
        </div>
      </div>
      <div className="mt-8 space-y-4 border-t border-white/10 pt-4">
        <div className="flex items-end justify-between">
          <div className="h-8 w-20 bg-white/10 rounded" />
          <div className="h-4 w-16 bg-white/10 rounded" />
        </div>
        <div className="h-10 w-full bg-white/10 rounded-full" />
      </div>
    </div>
  );
}

export function LoadingPage() {
  return (
    <div className="flex min-h-[60vh] items-center justify-center">
      <div className="text-center space-y-4">
        <LoadingSpinner size="lg" />
        <p className="text-slate-400 text-sm">Loading...</p>
      </div>
    </div>
  );
}

<?php

namespace App\Http\Middleware;

use Closure;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Log;
use Symfony\Component\HttpFoundation\Response;

class LogAccess
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $request->start_time = microtime(true);
        $response = $next($request);
        $this->logAccess($request, $response);

        return $response;
    }

    protected function logAccess(Request $request, Response $response): void
    {
        try {
            $logData = [
                'timestamp' => now()->format('Y-m-d H:i:s.u'), 
                'request' => [
                    'method' => $request->method(),
                    'uri' => $request->fullUrl(),
                    'path' => $request->path(),
                    'ip' => $request->ip(),
                    'user_agent' => $request->header('User-Agent'),
                    'referrer' => $request->header('Referer'),
                    'content_type' => $request->header('Content-Type'),
                    'input' => $request->all(), 
                    'headers' => $request->headers->all(), 
                    'x_amzn_trace_id' => $request->header('X-Amzn-Trace-Id'), // 透传 X-Amzn-Trace-Id
                ],
                'response' => [
                    'status' => $response->getStatusCode(),
                    'content_length' => strlen($response->getContent()),
                    'response_time_ms' => round((microtime(true) - $request->start_time) * 1000, 2),
                ],
                'user' => null,
            ];
            if ($request->user()) {
                $logData['user'] = [
                    'id' => $request->user()->id,
                    'name' => $request->user()->name ?? $request->user()->email,
                ];
            }

            Log::channel('accesslog')->info('Access Log', $logData);

        } catch (\Exception $e) {
            Log::error('Failed to write access log: ' . $e->getMessage());
        }
    }
}

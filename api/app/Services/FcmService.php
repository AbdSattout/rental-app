<?php

namespace App\Services;

use Illuminate\Support\Facades\Log;
use Kreait\Firebase\Messaging\CloudMessage;
use Kreait\Firebase\Messaging\Notification;

class FcmService
{
    public static function sendNotification( string $token,string $title,string $body,array $data = [])
    {
        if (!$token) {
            return false;
        }

        $messaging = app('firebase.messaging');

           // FCM requires all data values to be strings
        $data = array_map('strval', $data);

        $message = CloudMessage::withTarget('token', $token)
            ->withNotification(Notification::create($title, $body))
            ->withData($data);

        try {
            $messaging->send($message);
            return true;
        } catch (\Exception $e) {
            Log::error("FCM Error: " . $e->getMessage());
            return false;
        }
    }
}
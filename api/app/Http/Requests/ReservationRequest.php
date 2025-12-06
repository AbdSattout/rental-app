<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ReservationRequest extends FormRequest
{
    /**
     * Determine if the user is authorized to make this request.
     */
    public function authorize(): bool
    {
        return true;
    }

    /**
     * Get the validation rules that apply to the request.
     *
     * @return array<string, \Illuminate\Contracts\Validation\ValidationRule|array<mixed>|string>
     */
    public function rules(): array
    {
        return [
            //'post_id' => 'exists:posts,id',
            'check_in' => 'required|date',
            'check_out' => 'required|date|after:check_in',
           // 'status' => 'in:Pending,Accepted,Rejected,Cancelled',
        ];
    }
}

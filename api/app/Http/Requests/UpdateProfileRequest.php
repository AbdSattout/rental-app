<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdateProfileRequest extends FormRequest
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
            'first_name'=> ['sometimes','string','max:25'],
            'last_name'=> ['sometimes','string','max:25'],
            'Date_Of_Birth'=>['sometimes','date'],
            'Bio'=>['sometimes','string'],
            'ID_image'=>['sometimes','image','mimes:png,jpg,jpeg,gif','max:4096'],
            'profile_image'=>['sometimes','image','mimes:png,jpg,jpeg,gif','max:4096']
        ];
    }
}

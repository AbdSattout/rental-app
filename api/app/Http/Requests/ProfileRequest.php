<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class ProfileRequest extends FormRequest
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
            'first_name'=> 'required|string|max:25',
            'last_name'=>'required|string|max:25',
            'Date_Of_Birth'=>'required|date',
            'ID_image'=>'required|image|mimes:png,jpg,jpeg,gif|max:4096',
            'profile_image'=>'required|image|mimes:png,jpg,jpeg,gif|max:4096'
        ];
    }
}

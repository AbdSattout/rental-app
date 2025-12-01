<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePostRequest extends FormRequest
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
            "type"=>"sometimes|required|in:House,Apartment,Villa,Office",
            "space"=>"sometimes|required|numeric",
            "rooms"=>"sometimes|required|integer",
            "price"=>"sometimes|required|numeric|min:0",
            "latitude"=>"sometimes|required",
            "longitude"=>"sometimes|required",
            "availability"=>"sometimes|nullable|boolean",
            "photos"=>"sometimes|required|array|max:5|min:1",
            "photo.*"=>"sometimes|required|image|mimes:jpeg,png,jpg,gif,svg|max:2048",
        ];
    }
}

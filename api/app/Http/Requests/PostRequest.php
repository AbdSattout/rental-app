<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class PostRequest extends FormRequest
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

                "type"=>"required|in:house,apartment,villa,office",
                "space"=>"required|numeric",
                "rooms"=>"required|integer",
                "bathrooms"=>"required|integer",
                "price"=>"required|numeric|min:0",
                "latitude"=>"required|numeric|min:-90|max:90",
                "longitude"=>"required|numeric|min:-180|max:180",
                "photos"=>"required|array|min:1|max:5",
                "photos.*"=>"required|image|mimes:jpeg,png,jpg,gif,svg|max:2048",

        ];
    }
}

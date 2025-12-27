<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;

class FilterPostRequest extends FormRequest
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
            'min_price'=>'sometimes|nullable|numeric|min:0',
            'max_price'=>'sometimes|nullable|numeric|min:0',
            'min_rooms'=>'sometimes|nullable|integer|min:0',
            'max_rooms'=>'sometimes|nullable|integer|min:0',
            'type'=>'sometimes|nullable|in:house,apartment,villa,office',
            'rating'=>'sometimes|nullable|integer|min:0|max:5',
            'user_lat'=>'sometimes|nullable|numeric|between:-90,90',
            'user_lng'=>'sometimes|nullable|numeric|between:-180,180',
            'radius'=>'sometimes|nullable|numeric|min:1|max:1000',
            'required_with:user_lng'=>'user_lat',
            'required_with:user_lat'=>'user_lng',


        ];
    }
}

<?php

namespace App\Http\Requests;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Support\Facades\Auth;
use Illuminate\Validation\Rule;

class RatingRequest extends FormRequest
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
        $postID = $this->route('post')->id;
        return [
            'rating' => 'required|integer|min:1|max:5',
              Rule::unique('ratings')->where(function ($query) use ($postID) {
                return $query ->where('user_id', Auth::id())
                ->where('post_id', $postID);
            }),
            'review' => 'nullable|string|max:1000',
        ];
    }
}

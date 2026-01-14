<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\Profile>
 */
class ProfileFactory extends Factory
{
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {
        return [
            'user_id' => fake()->unique()->numberBetween(1, 44),
            'first_name' => fake()->firstName(),
            'last_name'=>fake()->lastName(),
            'bio'=>fake()->text(),
            'date_of_birth'=>fake()->date(),

        ];
    }
}

<?php

namespace Database\Factories;

use Illuminate\Database\Eloquent\Factories\Factory;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Str;

/**
 * @extends \Illuminate\Database\Eloquent\Factories\Factory<\App\Models\User>
 */
class UserFactory extends Factory
{
    /**
     * The current password being used by the factory.
     */
    protected static ?string $password;
    protected static array $numbers =[  '0975109096',
                '0988558906',
                '0966079185',
                '0914402760',
                '0994286100',
                '0954031315',
                '0912499987',
                '0956150040',
                '0927938944',
                '0984588401',
                '0981912853',
                '0901245259',
                '0931338983',
                '0931640150',
                '0931657532',
                '0901739783',
                '0923272489',
                '0970812560',
                '0983967318',
                '0952343103',
                '0978654214',
                '0949658653',
                '0946312799',
                '0982943915',
                '0905001293',
                '0939128261',
                '0937713672',
                '0968144835',
                '0933283025',
                '0943309632',
                '0961290530',
                '0950139836',
                '0944988251',
                '0962663958',
                '0948730288',
                '0951789194',
                '0962929574',
                '0946708387',
                '0948574543',
                '0980286868',
                '0930358687',
                '0959113632',
                '0952159317',
                '0994869722',
                '0984309785',
                '0966217708',
                '0933194917',
                '0968587412',
                '0950735839',
                '0907416814',
            ];
    /**
     * Define the model's default state.
     *
     * @return array<string, mixed>
     */
    public function definition(): array
    {

        $phoneNumber = array_pop(static::$numbers);
        return [
            'phone_number' => $phoneNumber,
          //  'email' => fake()->unique()->safeEmail(),
//'email_verified_at' => now(),
            'password' => static::$password ??= Hash::make('password'),
            'role'=>fake()->randomElement(['tenant' ,'host' , 'guest' , 'admin']),
            'remember_token' => Str::random(10),
            'fcm_token' => Str::random(10),
        ];
    }

    /**
     * Indicate that the model's email address should be unverified.
     */
    public function unverified(): static
    {
        return $this->state(fn (array $attributes) => [
            'email_verified_at' => null,
        ]);
    }
}

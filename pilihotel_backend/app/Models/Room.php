<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Room extends Model
{
    use HasFactory;

    protected $fillable = [
        'hotel_id',
        'name',
        'capacity',
        'bed_count',
        'bathroom_count',
        'price_per_night',
        'description',
        'facilities',
        'photos',
    ];

    protected function casts(): array
    {
        return [
            'capacity' => 'integer',
            'bed_count' => 'integer',
            'bathroom_count' => 'integer',
            'price_per_night' => 'integer',
            'facilities' => 'array',
            'photos' => 'array',
        ];
    }

    public function hotel(): BelongsTo
    {
        return $this->belongsTo(Hotel::class);
    }

    public function bookings(): HasMany
    {
        return $this->hasMany(Booking::class);
    }

    public function reviews(): HasMany
    {
        return $this->hasMany(Review::class);
    }
}

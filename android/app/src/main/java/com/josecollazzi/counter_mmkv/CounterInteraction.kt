package com.josecollazzi.counter_mmkv

data class CounterInteraction(
    val counterValue: Int,
    val interactionButtonLocation: String,
    val persistedLogicLocation: String
)

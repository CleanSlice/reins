<script setup lang="ts">
defineProps<{
  modelValue?: string;
  type?: string;
  id?: string;
  placeholder?: string;
}>();
const emit = defineEmits<{ 'update:modelValue': [value: string] }>();

function onInput(event: Event): void {
  const target = event.target;
  if (target instanceof HTMLInputElement) {
    emit('update:modelValue', target.value);
  }
}
</script>

<template>
  <input
    :id="id"
    :type="type ?? 'text'"
    :value="modelValue"
    :placeholder="placeholder"
    class="reins-stub-input"
    @input="onInput"
  />
</template>

<script setup lang="ts">
defineProps<{
  modelValue?: string;
  id?: string;
  placeholder?: string;
  rows?: string | number;
}>();
const emit = defineEmits<{ 'update:modelValue': [value: string] }>();

function onInput(event: Event): void {
  const target = event.target;
  if (target instanceof HTMLTextAreaElement) {
    emit('update:modelValue', target.value);
  }
}
</script>

<template>
  <textarea
    :id="id"
    :value="modelValue"
    :placeholder="placeholder"
    :rows="rows"
    class="reins-stub-textarea"
    @input="onInput"
  ></textarea>
</template>

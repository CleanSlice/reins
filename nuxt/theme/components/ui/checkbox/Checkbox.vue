<script setup lang="ts">
defineProps<{ modelValue?: boolean | 'indeterminate'; id?: string }>();
const emit = defineEmits<{ 'update:modelValue': [value: boolean | 'indeterminate'] }>();

function onChange(event: Event): void {
  const target = event.target;
  if (target instanceof HTMLInputElement) {
    emit('update:modelValue', target.checked);
  }
}
</script>

<template>
  <input
    type="checkbox"
    :id="id"
    :checked="modelValue === true"
    class="reins-stub-checkbox"
    @change="onChange"
  />
</template>

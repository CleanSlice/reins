<script setup lang="ts">
defineProps<{
  variant?: string;
  size?: string;
  type?: string;
  disabled?: boolean;
}>();
</script>

<template>
  <button :type="type ?? 'button'" :disabled="disabled" class="reins-stub-button">
    <slot />
  </button>
</template>

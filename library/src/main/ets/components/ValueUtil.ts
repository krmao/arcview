const randomColor = (alpha?: number | undefined): string => {
  const r = Math.floor(Math.random() * 256);
  const g = Math.floor(Math.random() * 256);
  const b = Math.floor(Math.random() * 256);
  return `rgba(${r}, ${g}, ${b}, ${alpha ?? 1})`;
}


const ValueUtil = {
  randomColor,
};

export default ValueUtil;

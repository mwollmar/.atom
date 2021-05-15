import commonjs from '@rollup/plugin-commonjs';
import typescript from '@rollup/plugin-typescript';

const plugins = [
  commonjs(),
  typescript({
    allowSyntheticDefaultImports: true,
    lib: [
      'dom',
      'esnext'
    ],
    noImplicitAny: true,
    typeRoots: [
      './node_modules/@types',
      './types'
    ]
  })
];

export default [
  {
    input: 'src/index.ts',
    output: {
      dir: 'lib',
      format: 'esm'
    },
    plugins
  }
];

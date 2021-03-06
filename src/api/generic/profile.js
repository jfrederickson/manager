import {
  genConfig, ReducerGenerator, genActions, ONE, PUT,
} from '~/api/internal';

export const config = genConfig({
  singular: 'profile',
  endpoint: () => '/profile',
  supports: [ONE, PUT],
});

export const actions = genActions(config);
export const { reducer } = new ReducerGenerator(config);

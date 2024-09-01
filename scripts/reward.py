#!/usr/bin/python
import numpy as np

def calc_reward(obs):
    track = np.array(obs['track'])
    sp = np.array(obs['speedX'])
    progress = sp*np.cos(obs['angle'])

    r = sp*np.cos(obs['angle']) - np.abs(sp*np.sin(obs['angle'])) - sp * np.abs(obs['trackPos'])

    return r

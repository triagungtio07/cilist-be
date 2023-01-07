#! /bin/bash


if ! kubectl rollout status deployment  cilist-be-dev -n dev; then
    kubectl rollout undo deployment  cilist-be-dev -n dev
    kubectl rollout status deployment  cilist-be-dev -n dev
    exit 1
fi
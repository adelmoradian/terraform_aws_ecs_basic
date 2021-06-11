#! /bin/bash
echo ECS_CLUSTER=${CLUSTER_NAME} >> /etc/ecs/ecs.config
echo ECS_ENABLE_CONTAINER_METADATA=true >> /etc/ecs/ecs.config

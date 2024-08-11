import os
import docker
from docker.errors import NotFound, APIError
from datetime import datetime

# Initialize the Docker client
client = docker.from_env()

def get_date_based_path(base_path, container_name, container_id, file_suffix):
    date_str = datetime.now().strftime("%Y-%m-%d")
    directory_path = os.path.join(base_path, date_str)
    specific_path = os.path.join(directory_path, container_name + "_" + container_id + file_suffix)
    os.makedirs(os.path.dirname(specific_path), exist_ok=True)
    return specific_path

def list_containers():
    containers = client.containers.list(all=True)
    if not containers:
        print("No containers found.")
    else:
        for container in containers:
            print(f"ID: {container.id}, Name: {container.name}, Status: {container.status}")

def start_container(container_name):
    try:
        container = client.containers.get(container_name)
        container.start()
        print(f"Started container {container.name} with ID {container.id}")
    except NotFound:
        print(f"Container {container_name} not found")
    except APIError as e:
        print(f"Error starting container: {e.explanation}")

def stop_container(container_name):
    try:
        container = client.containers.get(container_name)
        container.stop()
        print(f"Stopped container {container.name} with ID {container.id}")
    except NotFound:
        print(f"Container {container_name} not found")
    except APIError as e:
        print(f"Error stopping container: {e.explanation}")

def remove_container(container_name):
    try:
        container = client.containers.get(container_name)
        container.remove()
        print(f"Removed container {container.name} with ID {container.id}")
    except NotFound:
        print(f"Container {container_name} not found")
    except APIError as e:
        print(f"Error removing container: {e.explanation}")

def run_container(image_name, container_name):
    try:
        container = client.containers.run(image_name, name=container_name, detach=True)
        print(f"Started new container {container.name} with ID {container.id} from image {container.image.tags[0]}")
    except APIError as e:
        print(f"Error running container: {e.explanation}")

def inspect_container(container_id):
    try:
        container = client.containers.get(container_id)
        details = container.attrs
        file_path = get_date_based_path("/root/docker/container_details", container.name, container_id, "_details_file.txt")
        with open(file_path, 'w') as file:
            file.write(str(details))
        print(f"Details of container {container.name} with ID {container_id} written to {file_path}")
    except NotFound:
        print(f"Container {container_id} not found")
    except APIError as e:
        print(f"Error inspecting container: {e.explanation}")

def inspect_network(container_id):
    try:
        container = client.containers.get(container_id)
        networks = container.attrs['NetworkSettings']['Networks']
        file_path = get_date_based_path("/root/docker/container_network_details", container.name, container_id, "_network_details_file.txt")
        with open(file_path, 'w') as file:
            file.write(str(networks))
        print(f"Network information of container {container.name} with ID {container_id} written to {file_path}")
    except NotFound:
        print(f"Container {container_id} not found")
    except APIError as e:
        print(f"Error inspecting network: {e.explanation}")

def get_logs(container_id):
    try:
        container = client.containers.get(container_id)
        logs = container.logs()
        file_path = get_date_based_path("/root/docker/logs", container.name, container_id, "_logs.txt")
        with open(file_path, 'w') as file:
            file.write(logs.decode('utf-8'))
        print(f"Logs of container {container.name} with ID {container_id} written to {file_path}")
    except NotFound:
        print(f"Container {container_id} not found")
    except APIError as e:
        print(f"Error retrieving logs: {e.explanation}")

def restart_container(container_id):
    try:
        container = client.containers.get(container_id)
        container.restart()
        print(f"Restarted container {container.name} with ID {container_id}")
    except NotFound:
        print(f"Container {container_id} not found")
    except APIError as e:
        print(f"Error restarting container: {e.explanation}")

def pause_container(container_id):
    try:
        container = client.containers.get(container_id)
        container.pause()
        print(f"Paused container {container.name} with ID {container_id}")
    except NotFound:
        print(f"Container {container_id} not found")
    except APIError as e:
        print(f"Error pausing container: {e.explanation}")

def unpause_container(container_id):
    try:
        container = client.containers.get(container_id)
        container.unpause()
        print(f"Unpaused container {container.name} with ID {container_id}")
    except NotFound:
        print(f"Container {container_id} not found")
    except APIError as e:
        print(f"Error unpausing container: {e.explanation}")

def exec_command(container_id, cmd):
    try:
        container = client.containers.get(container_id)
        exec_id = client.api.exec_create(container_id, cmd)
        output = client.api.exec_start(exec_id)
        print(f"Command output for container {container.name} with ID {container_id}:\n{output.decode('utf-8')}")
    except NotFound:
        print(f"Container {container_id} not found")
    except APIError as e:
        print(f"Error executing command: {e.explanation}")

def commit_container(container_id, repository, tag):
    try:
        container = client.containers.get(container_id)
        image = container.commit(repository=repository, tag=tag)
        print(f"Committed container {container.name} with ID {container_id} to image {image.tags[0]}")
    except NotFound:
        print(f"Container {container_id} not found")
    except APIError as e:
        print(f"Error committing container: {e.explanation}")

def get_stats(container_id):
    try:
        container = client.containers.get(container_id)
        stats = container.stats(stream=False)
        file_path = get_date_based_path("/root/docker/stats", container.name, container_id, "_stats.txt")
        with open(file_path, 'w') as file:
            file.write(str(stats))
        print(f"Stats of container {container.name} with ID {container_id} written to {file_path}")
    except NotFound:
        print(f"Container {container_id} not found")
    except APIError as e:
        print(f"Error retrieving stats: {e.explanation}")

def copy_to_container(container_id, src, dest):
    try:
        container = client.containers.get(container_id)
        with open(src, 'rb') as file:
            container.put_archive(dest, file.read())
        print(f"Copied {src} to container {container.name} with ID {container_id} at {dest}")
    except NotFound:
        print(f"Container {container_id} not found")
    except APIError as e:
        print(f"Error copying file to container: {e.explanation}")

def copy_from_container(container_id, src, dest):
    try:
        container = client.containers.get(container_id)
        bits, _ = container.get_archive(src)
        with open(dest, 'wb') as file:
            for chunk in bits:
                file.write(chunk)
        print(f"Copied {src} from container {container.name} with ID {container_id} to {dest}")
    except NotFound:
        print(f"Container {container_id} not found")
    except APIError as e:
        print(f"Error copying file from container: {e.explanation}")

def display_options():
    print("\nAvailable operations:")
    print("1. List Containers")
    print("2. Start Container")
    print("3. Stop Container")
    print("4. Remove Container")
    print("5. Run New Container")
    print("6. Inspect Container Details")
    print("7. Inspect Container Network")
    print("8. Get Container Logs")
    print("9. Restart Container")
    print("10. Pause Container")
    print("11. Unpause Container")
    print("12. Execute Command in Container")
    print("13. Commit Container Changes")
    print("14. Get Container Stats")
    print("15. Copy File to Container")
    print("16. Copy File from Container")

def main():
    display_options()
    operations = input("\nEnter a list of operations (comma-separated numbers) to perform: ")
    operations = [op.strip() for op in operations.split(',')]

    container_id = input("Enter container ID: ")

    for choice in operations:
        if choice == '1':
            list_containers()
        elif choice == '2':
            start_container(container_id)
        elif choice == '3':
            stop_container(container_id)
        elif choice == '4':
            remove_container(container_id)
        elif choice == '5':
            image_name = input("Enter image name to run: ")
            container_name = input("Enter container name: ")
            run_container(image_name, container_name)
        elif choice == '6':
            inspect_container(container_id)
        elif choice == '7':
            inspect_network(container_id)
        elif choice == '8':
            get_logs(container_id)
        elif choice == '9':
            restart_container(container_id)
        elif choice == '10':
            pause_container(container_id)
        elif choice == '11':
            unpause_container(container_id)
        elif choice == '12':
            cmd = input("Enter command to execute: ")
            exec_command(container_id, cmd)
        elif choice == '13':
            repository = input("Enter repository name: ")
            tag = input("Enter tag: ")
            commit_container(container_id, repository, tag)
        elif choice == '14':
            get_stats(container_id)
        elif choice == '15':
            src = input("Enter source file path: ")
            dest = input("Enter destination path inside container: ")
            copy_to_container(container_id, src, dest)
        elif choice == '16':
            src = input("Enter source path inside container: ")
            dest = input("Enter destination file path: ")
            copy_from_container(container_id, src, dest)
        else:
            print(f"Invalid choice {choice}. Please try again.")

if __name__ == "__main__":
    main()

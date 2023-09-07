document.addEventListener("DOMContentLoaded", function () {
  // Replace 'html-files' with the folder path you want to list files from.
  const folderPath = "/config.json";

  // Fetch the list of files in the folder.
  fetchSettings(folderPath)
    .then((settings) => {
      console.log(settings);

      document.title = settings.title;

    })
    .catch((error) => {
      console.error("Error fetching folder contents:", error);
    });
});

async function fetchSettings(folderPath) {
  const settings = await fetch("/config.json");
  return settings.json();
}

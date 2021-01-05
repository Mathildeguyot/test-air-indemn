const toggleReach = () => {
  const yes = document.querySelector(".form_check");
  const no = document.querySelector("#deposition_forward_true");
  const reach = document.querySelector(".reach");

  yes.addEventListener('click', (event) => {
    console.log(event);
    reach.classList.remove(".reach");
  });

  no.addEventListener('click', (event) => {
    reach.classList.add(".reach");
  });
};

export { toggleReach };

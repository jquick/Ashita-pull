# Pull
This is a simple ffxi plugin based off Checker which will convert the `/check` command into a party message. This is usefull when pulling mobs to the party.

### Usage
In order to use this plugin you will need to make a macro with the following code
```
/pullToggle
/check
```

The first line will enable the `/check` override for once instance and output it to the party instead. Normal `/check` usage will continue to work as expected without the toggle.


You can optinally add any text to the end of `/pullToggle` and it will be appended to the party chat. This is helpful if you wish to add a sound effect to the message.

```
/pullToggle <call21>
/check
```


### Example
![config](https://i.imgur.com/VUjpLnJ.png)

![output](https://i.imgur.com/ejL5nVh.png)

With addtional output:

![output2](https://i.imgur.com/HMetbVB.png))